CC       ?= gcc
CXX      ?= g++

CXXFLAGS += -std=c++20 -Wall -Wextra -Wpedantic -fno-exceptions -fno-rtti -I.

ifeq ($(BUILD_TYPE), Debug)
    CXXFLAGS += -O0 -g -fsanitize=address,undefined -fno-omit-frame-pointer
    LDFLAGS  += -fsanitize=address,undefined
else
    BUILD_TYPE = Release
    CXXFLAGS += -O3 -march=native -DNDEBUG
endif

COMMON_DIR = common
SRC_DIR    = $(COMMON_DIR)/src
TEST_DIR   = $(COMMON_DIR)/tests
BUILD_ROOT = build/$(BUILD_TYPE)

SRCS       = $(SRC_DIR)/poly.cc $(SRC_DIR)/ntt.cc
OBJS       = $(patsubst $(SRC_DIR)/%.cc, $(BUILD_ROOT)/%.o, $(SRCS))

TEST_TARGET = $(BUILD_ROOT)/test_runner

.PHONY: all test clean

all: $(TEST_TARGET)

$(TEST_TARGET): $(OBJS) $(TEST_DIR)/test_poly.cc
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) $^ -o $@ $(LDFLAGS)

$(BUILD_ROOT)/%.o: $(SRC_DIR)/%.cc $(SRC_DIR)/%.h $(SRC_DIR)/types.h $(SRC_DIR)/modmath.h
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

test: $(TEST_TARGET)
	@echo "Running FHE mathematical engine tests..."
	@./$(TEST_TARGET)

clean:
	rm -rf build

