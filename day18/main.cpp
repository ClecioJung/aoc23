#include <algorithm>
#include <cassert>
#include <iostream>
#include <fstream>
#include <numeric>
#include <string>
#include <vector>

struct Dig {
    char direction;
    long length;
    uint32_t color;

    Dig(char dir, long len, uint32_t color): direction(dir), length(len), color(color) {}
};

std::vector<Dig> parse_input(std::string file_path) {
    std::ifstream input_file(file_path);
    std::string line;
    std::vector<Dig> dig_plan;
    while (std::getline(input_file, line)) {
        const char dir = line[0];
        size_t charsParsed = 1;
        const long len = std::stoi(line.substr(2), &charsParsed);
        const int color = std::stoi(line.substr(5 + charsParsed), nullptr, 16);
        dig_plan.push_back(Dig(dir, len, color));
    }
    input_file.close();
    return dig_plan;
}

std::vector<Dig>& swap_color_instruction(std::vector<Dig>& dig_plan) {
    for (auto& dig : dig_plan) {
        dig.length = dig.color >> 4;
        switch (dig.color & 0xF) {
        case 0:
            dig.direction = 'R';
            break;
        case 1:
            dig.direction = 'D';
            break;
        case 2:
            dig.direction = 'L';
            break;
        case 3:
            dig.direction = 'U';
            break;
        default:
            assert(0 && "unreachable");
        };
    }
    return dig_plan;
}

struct Vertice {
    long x;
    long y;

    Vertice(int x, int y): x(x), y(y) {}
};

std::vector<Vertice> build_vertices(const std::vector<Dig>& dig_plan) {
    Vertice current_point = Vertice(0, 0);
    std::vector<Vertice> vertices;
    for (auto dig : dig_plan) {
        vertices.push_back(current_point);
        switch (dig.direction) {
        case 'R':
            current_point.x += dig.length;
            break;
        case 'L':
            current_point.x -= dig.length;
            break;
        case 'D':
            current_point.y += dig.length;
            break;
        case 'U':
            current_point.y -= dig.length;
            break;
        default:
            assert(0 && "unreachable");
        }
    }
    assert(current_point.x == 0);
    assert(current_point.y == 0);
    return vertices;
}

long perimeter(const std::vector<Vertice>& vertices) {
    long perimeter = 0;
    for (size_t i = 0; i < vertices.size(); i++) {
        auto current_vertice = vertices[i];
        auto next_vertice = vertices[(i+1) % vertices.size()];
        perimeter += std::abs(current_vertice.x-next_vertice.x) + std::abs(current_vertice.y-next_vertice.y);
    }
    return perimeter;
}

// Shoelace formula
long shoelace(const std::vector<Vertice>& vertices) {
    long area = 0;
    for (size_t i = 0; i < vertices.size(); i++) {
        auto current_vertice = vertices[i];
        auto next_vertice = vertices[(i+1) % vertices.size()];
        area += current_vertice.x * next_vertice.y - current_vertice.y * next_vertice.x;
    }
    return std::abs(area) / 2;
}

// Pick's Theorem
long area(const std::vector<Vertice>& vertices) {
    return shoelace(vertices) + perimeter(vertices) / 2 + 1;
}

long part01(std::string file_path) {
    auto dig_plan = parse_input(file_path);
    auto vertices = build_vertices(dig_plan);
    return area(vertices);
}

long part02(std::string file_path) {
    auto dig_plan = parse_input(file_path);
    swap_color_instruction(dig_plan);
    auto vertices = build_vertices(dig_plan);
    return area(vertices);
}

int main(void) {
    assert(part01("sample.txt") == 62);
    auto part01output = part01("input.txt");
    assert(part01output == 41019);
    std::cout << "Part 01: " << part01output << std::endl;
    assert(part02("sample.txt") == 952408144115);
    auto part02output = part02("input.txt");
    assert(part02output == 96116995735219);
    std::cout << "Part 02: " << part02output << std::endl;
    return EXIT_SUCCESS;
}
