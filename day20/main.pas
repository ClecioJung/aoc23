program day20;

type
    TStringArray = array of string;
    TUint64Array = array of UInt64;
    TBooleanArray = array of Boolean;

    TModuleTypes = (FlipFlop, Conjunction, Broadcaster);

    TState = record
        FlipFlop: Boolean;
        Conjunction: TBooleanArray;
    end;

    TStateArray = array of TState;

    TCommModule = record
        ModuleType: TModuleTypes;
        ModuleName: string;
        Connections: TStringArray;
        ConjunctionInputs: TStringArray;
    end;

    TCommModules = array of TCommModule;

    TPulses = record
        High: Uint64;
        Low: Uint64;
    end;

    TSignal = record
        FromModule: String;
        ToModule: string;
        SignalValue: Boolean;
    end;

    TSignalArray = array of TSignal;

    PSignal = ^TSignal;

function ParseConnections(const Connections: string): TStringArray;
var
    startIndex, commaIndex: Integer;
begin
    SetLength(ParseConnections, 0);
    startIndex := 1;
    while startIndex <= Length(Connections) do
    begin
        commaIndex := Pos(',', Connections, startIndex);
        if commaIndex = 0 then
        begin
            commaIndex := Length(Connections) + 1;
        end;
        SetLength(ParseConnections, Length(ParseConnections) + 1);
        ParseConnections[High(ParseConnections)] := Copy(Connections, startIndex, commaIndex - startIndex);
        startIndex := commaIndex + 2;
    end;
end;

function FindModule(const modules: TCommModules; const moduleName: string): Integer;
var
    i: Integer;
begin
    FindModule := -1;
    for i := Low(modules) to High(modules) do
    begin
        if modules[i].ModuleName = moduleName then
        begin
            FindModule := i;
            break;
        end;
    end;
end;

procedure InitializeListOfInputs(var modules: TCommModules);
var
    i, j, foundIndex: Integer;
begin
    for i := Low(modules) to High(modules) do
    begin
        for j := Low(modules[i].Connections) to High(modules[i].Connections) do
        begin
            foundIndex := FindModule(modules, modules[i].Connections[j]);
            if foundIndex >= 0 then
            begin
                if modules[foundIndex].ModuleType = Conjunction then
                begin
                    SetLength(modules[foundIndex].ConjunctionInputs, Length(modules[foundIndex].ConjunctionInputs)+1);
                    modules[foundIndex].ConjunctionInputs[High(modules[foundIndex].ConjunctionInputs)] := modules[i].ModuleName;
                end;
            end;
        end;
    end;
end;

function FindConnectionsTo(const modules: TCommModules; const moduleName: string): TStringArray;
var
    i, j: Integer;
begin
    SetLength(FindConnectionsTo, 0);
    for i := Low(modules) to High(modules) do
    begin
        for j := Low(modules[i].Connections) to High(modules[i].Connections) do
        begin
            if modules[i].Connections[j] = moduleName then
            begin
                SetLength(FindConnectionsTo, Length(FindConnectionsTo)+1);
                FindConnectionsTo[High(FindConnectionsTo)] := modules[i].ModuleName;
            end;
        end;
    end;
end;

function ParseInput(const fileName: string): TCommModules;
var
    inputFile: Text;
    line: string;
    arrowPos: Integer;
begin
    Assign(inputFile, fileName);
    Reset(inputFile);
    SetLength(ParseInput, 0);
    while not EOF(inputFile) do
    begin
        ReadLn(inputFile, line);
        arrowPos := Pos('->', line);
        SetLength(ParseInput, Length(ParseInput) + 1);
        ParseInput[High(ParseInput)].Connections := ParseConnections(Copy(line, arrowPos+3, Length(line)-arrowPos-1));
        SetLength(ParseInput[High(ParseInput)].ConjunctionInputs, 0);
        case line[1] of
        '%': // flip-flop
        begin
            ParseInput[High(ParseInput)].ModuleName := Copy(line, 2, arrowPos-3);
            ParseInput[High(ParseInput)].ModuleType := FlipFlop;
        end;
        '&': // conjunction module
        begin
            ParseInput[High(ParseInput)].ModuleName := Copy(line, 2, arrowPos-3);
            ParseInput[High(ParseInput)].ModuleType := Conjunction;
        end;
        else // broadcaster
        begin
            ParseInput[High(ParseInput)].ModuleName := Copy(line, 1, arrowPos-2);
            ParseInput[High(ParseInput)].ModuleType := Broadcaster;
        end;
        end;
    end;
    Close(inputFile);
    // Initialize Conjunctions' list of inputs
    InitializeListOfInputs(ParseInput);
end;

function InitialStateArray(const modules: TCommModules): TStateArray;
var
    i, j: Integer;
begin
    SetLength(InitialStateArray, Length(modules));
    for i := low(modules) to High(modules) do
    begin
        InitialStateArray[i].FlipFlop := false;
        SetLength(InitialStateArray[i].Conjunction, Length(modules[i].ConjunctionInputs));
        for j := Low(InitialStateArray[i].Conjunction) to High(InitialStateArray[i].Conjunction) do
            InitialStateArray[i].Conjunction[j] := false;
    end;
end;

procedure SetConjunctionInput(const commModule: TCommModule; var conjunctionInputs: TBooleanArray; const inputModule: string; const signalValue: Boolean);
var
    i: Integer;
begin
    for i := Low(conjunctionInputs) to High(conjunctionInputs) do
    begin
        if commModule.ConjunctionInputs[i] = inputModule then
        begin
            conjunctionInputs[i] := signalValue;
            break;
        end
    end;
end;

function ActiveConjunctionInputs(const conjunctionInputs: TBooleanArray): Integer;
var
    i: Integer;
begin
    ActiveConjunctionInputs := 0;
    for i := Low(conjunctionInputs) to High(conjunctionInputs) do
    begin
        if conjunctionInputs[i] then Inc(ActiveConjunctionInputs);
    end;
end;

function processSignal(const commModule: TCommModule; var state: TState; const currentSignal: TSignal; var nextSignal: Boolean): Boolean;
begin
    processSignal := false;
    nextSignal := false;
    case commModule.ModuleType of
    FlipFlop:
        if currentSignal.SignalValue <> true then
        begin
            state.FlipFlop := not state.FlipFlop;
            processSignal := true;
            nextSignal := state.FlipFlop;
        end;
    Conjunction:
    begin
        SetConjunctionInput(commModule, state.Conjunction, currentSignal.FromModule, currentSignal.SignalValue);
        processSignal := true;
        nextSignal := ActiveConjunctionInputs(state.Conjunction) <> Length(state.Conjunction);
    end;
    Broadcaster:
    begin
        processSignal := true;
        nextSignal := currentSignal.SignalValue;
    end;
    end;
end;

procedure AddSignalsToQueue(var signalsQueue: TSignalArray; const connections: TStringArray; const fromModule: string; const signalValue: Boolean);
var
    i: Integer;
begin
    for i := Low(connections) to High(connections) do
    begin
        SetLength(signalsQueue, Length(signalsQueue)+1);
        signalsQueue[High(signalsQueue)].FromModule := fromModule;
        signalsQueue[High(signalsQueue)].ToModule := connections[i];
        signalsQueue[High(signalsQueue)].SignalValue := signalValue;
    end;
end;

function PerformPropagationCycle(const modules: TCommModules; var state: TStateArray; const debug: Boolean; const activatingSignal: PSignal; var activated: Boolean): TPulses;
var
    i: Integer;
    currentSignal: TSignal;
    signalsQueue: TSignalArray;
    moduleIndex: Integer;
    nextSignal: Boolean;
begin
    PerformPropagationCycle.Low := 0;
    PerformPropagationCycle.High := 0;
    SetLength(signalsQueue, 1);
    signalsQueue[High(signalsQueue)].FromModule := 'button';
    signalsQueue[High(signalsQueue)].ToModule := 'broadcaster';
    signalsQueue[High(signalsQueue)].SignalValue := false; // Low signal
    i := Low(signalsQueue);
    while i <= High(signalsQueue) do
    begin
        currentSignal := signalsQueue[i];
        if activatingSignal <> nil then
        begin
            if (currentSignal.ToModule = activatingSignal^.ToModule) and (currentSignal.SignalValue = activatingSignal^.SignalValue) then
                activated := true;
        end;
        if currentSignal.SignalValue then
        begin
            Inc(PerformPropagationCycle.High);
            if debug then writeln(currentSignal.FromModule, ' -high-> ', currentSignal.ToModule);
        end
        else
        begin
            Inc(PerformPropagationCycle.Low);
            if debug then writeln(currentSignal.FromModule, ' -low-> ', currentSignal.ToModule);
        end;
        moduleIndex := FindModule(modules, currentSignal.ToModule);
        if moduleIndex >= 0 then
            if processSignal(modules[moduleIndex], state[moduleIndex], currentSignal, nextSignal) then
                AddSignalsToQueue(signalsQueue, modules[moduleIndex].Connections, currentSignal.ToModule, nextSignal);
        Inc(i);
    end;
end;

function ComputePulsePropagation(const modules: TCommModules; const cycles: Integer; const debug: Boolean): Uint64;
var
    state: TStateArray;
    pulse: TPulses;
    pulseCount: TPulses;
    i: Integer;
    activated: Boolean;
begin
    pulseCount.Low := 0;
    pulseCount.High := 0;
    state := InitialStateArray(modules);
    for i := 0 to cycles-1 do
    begin
        if debug then writeln('Cycle ', i, ':');
        pulse := PerformPropagationCycle(modules, state, debug, nil, activated);
        pulseCount.Low := pulseCount.Low + pulse.Low;
        pulseCount.High := pulseCount.High + pulse.High;
        if debug then writeln;
    end;
    ComputePulsePropagation := pulseCount.High * pulseCount.Low;
    // Deallocate arrays
    for i := Low(state) to High(state) do
        SetLength(state[i].Conjunction, 0);
    SetLength(state, 0);
end;

function GCD(a, b: UInt64): UInt64;
begin
    GCD := a;
    while b <> 0 do
    begin
        a := GCD mod b;
        GCD := b;
        b := a;
    end;
end;

function LCM(const values: TUint64Array): UInt64;
var
    i: Integer;
begin
    LCM := 1;
    for i := Low(values) to High(values) do
    begin
        LCM := LCM * (values[i] div (GCD(LCM, values[i])));
    end;
end;

function ComputePeriod(const modules: TCommModules; const moduleName: string; const signalValue: Boolean): UInt64;
var
    state: TStateArray;
    i: Integer;
    expectedSignal: TSignal;
    activated: Boolean;
begin
    activated := false;
    ComputePeriod := 1;
    expectedSignal.FromModule := '';
    expectedSignal.ToModule := moduleName;
    expectedSignal.SignalValue := signalValue;
    state := InitialStateArray(modules);
    while true do
    begin
        PerformPropagationCycle(modules, state, false, @expectedSignal, activated);
        if activated then break;
        Inc(ComputePeriod);
    end;
    // Deallocate arrays
    for i := Low(state) to High(state) do
        SetLength(state[i].Conjunction, 0);
    SetLength(state, 0);
end;

function ComputeButtonPresses(const modules: TCommModules): UInt64;
var
    i: Integer;
    periods: TUint64Array;
    connectionsToOutput, connections: TStringArray;
begin
    ComputeButtonPresses := 0;
    {If we attempt the brute force solution in part 02, the processing time becomes excessive.
    The `rx` output collects pulses from the `vr` conjunction module, itself receiving pulses
    from the `bm`, `cl`, `tn`, and `dr` modules. Since all these modules operate periodically,
    we can employ an approach analogous to the one used in the challenge of day 8. By utilizing
    the Least Common Multiple (LCM) algorithm on the periods of the `bm`, `cl`, `tn`, and `dr`
    modules, we can efficiently determine the time at which the `rx` output will be triggered.}
    connectionsToOutput := FindConnectionsTo(modules, 'rx');
    if Length(connectionsToOutput) > 0 then
    begin
        connections := FindConnectionsTo(modules, connectionsToOutput[0]);
        if Length(connections) > 0 then
        begin
            SetLength(periods, Length(connections));
            for i := Low(connections) to High(connections) do
            begin
                periods[i] := ComputePeriod(modules, connections[i], false);
            end;
            ComputeButtonPresses := LCM(periods);
        end;
    end;
end;

function Part01(const fileName: string): UInt64;
var
    modules: TCommModules;
    i: Integer;
begin
    modules := ParseInput(fileName);
    Part01 := ComputePulsePropagation(modules, 1000, false);
    // Deallocate arrays
    for i := Low(modules) to High(modules) do
        SetLength(modules[i].Connections, 0);
    SetLength(modules, 0);
end;

function Part02(const fileName: string): UInt64;
var
    modules: TCommModules;
    i: Integer;
begin
    modules := ParseInput(fileName);
    Part02 := ComputeButtonPresses(modules);
    // Deallocate arrays
    for i := Low(modules) to High(modules) do
        SetLength(modules[i].Connections, 0);
    SetLength(modules, 0);
end;

procedure Assert(const condition: Boolean; const message: string);
begin
    if not condition then
    begin
        writeln('Assertion failed: ', message);
        Halt;
    end;
end;

procedure Main();
var
    part01output, part02output: UInt64;
begin
    Assert(Part01('sample1.txt') = 32000000, 'Part 01 failed for sample1.txt');
    Assert(Part01('sample2.txt') = 11687500, 'Part 01 failed for sample2.txt');
    part01output := Part01('input.txt');
    writeln('Part 01: ', part01output);
    Assert(part01output = 747304011, 'Part 01 failed for input.txt');
    part02output := Part02('input.txt');
    writeln('Part 02: ', part02output);
    Assert(part02output = 220366255099387, 'Part 02 failed for input.txt');
end;

begin
    Main;
end.
