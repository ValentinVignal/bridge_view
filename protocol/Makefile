# Makefile for generating Protocol Buffer code

.PHONY: all rust dart clean help

# Default target
all: rust dart

# Generate Rust code
rust:
	@echo "Generating Rust protocol buffers..."
	@mkdir -p ../server/src/proto
	protoc --prost_out=../server/src/proto \
		proto/display.proto
	@echo "✓ Rust code generated in ../server/src/proto"

# Generate Dart code
dart:
	@echo "Generating Dart protocol buffers..."
	@mkdir -p ../client/lib/proto
	protoc --dart_out=../client/lib/proto \
		proto/display.proto
	@echo "✓ Dart code generated in ../client/lib/proto"

# Clean generated files
clean:
	@echo "Cleaning generated protocol buffer files..."
	@rm -rf ../server/src/proto/*
	@rm -rf ../client/lib/proto/*
	@echo "✓ Cleaned"

# Display help
help:
	@echo "Bridge View Protocol - Code Generation"
	@echo ""
	@echo "Targets:"
	@echo "  all    - Generate code for both Rust and Dart (default)"
	@echo "  rust   - Generate Rust protocol buffer code"
	@echo "  dart   - Generate Dart protocol buffer code"
	@echo "  clean  - Remove all generated files"
	@echo "  help   - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - protoc (Protocol Buffer compiler)"
	@echo "  - protoc-gen-prost (Rust plugin)"
	@echo "  - protoc-gen-dart (Dart plugin)"
