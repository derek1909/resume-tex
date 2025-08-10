#!/bin/bash

# Resume Version Management Script
# Usage: ./manage_resume.sh [command] [options]

set -e

BUILD_DIR="built-pdf"
ARCHIVE_DIR="archive"
DATE=$(date +%Y-%m-%d)
DATETIME=$(date +%Y-%m-%d_%H-%M-%S)
EN_DIR="en"
CN_DIR="cn"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo "Resume Management Tool"
    echo ""
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  build [file]      Build specific resume or all resumes"
    echo "  clean            Clean build artifacts"
    echo "  archive          Archive current PDFs with timestamp"
    echo "  list             List all resume versions"
    echo "  diff [file1] [file2]  Show differences between two resume files"
    echo "  backup           Create git commit with current state"
    echo "  help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build jobs_resume.tex"
    echo "  $0 build"
    echo "  $0 archive"
    echo "  $0 list"
}

build_resume() {
    local file=$1
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"
    
    if [ -z "$file" ]; then
        echo -e "${BLUE}Building all resume files...${NC}"
        
        # Build English resumes
        echo -e "${YELLOW}Building English resumes...${NC}"
        for tex_file in "$EN_DIR"/*.tex; do
            if [[ "$tex_file" != *"experience_pool.tex" ]]; then
                local filename=$(basename "$tex_file")
                local base_name="${filename%.tex}"
                local pdf_name="${base_name}_${DATE}.pdf"
                
                echo -e "${YELLOW}Building $filename -> $pdf_name...${NC}"
                
                cd "$EN_DIR"
                pdflatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                local build_status=$?
                
                # Check if PDF was actually generated regardless of exit status
                if [ -f "temp/${base_name}.pdf" ]; then
                    mv "temp/${base_name}.pdf" "../$BUILD_DIR/$pdf_name"
                    if [ -f "../$BUILD_DIR/$pdf_name" ]; then
                        echo -e "${GREEN}✓ Successfully built $pdf_name${NC}"
                    else
                        echo -e "${RED}✗ Failed to move $pdf_name${NC}"
                    fi
                else
                    echo -e "${RED}✗ Failed to build $filename${NC}"
                fi
                cd ..
            fi
        done
        
        # Build Chinese resumes
        echo -e "${YELLOW}Building Chinese resumes...${NC}"
        for tex_file in "$CN_DIR"/*.tex; do
            if [[ "$tex_file" != *"experience_pool_cn.tex" ]]; then
                local filename=$(basename "$tex_file")
                local base_name="${filename%.tex}"
                local pdf_name="${base_name}_${DATE}.pdf"
                
                echo -e "${YELLOW}Building $filename -> $pdf_name...${NC}"
                
                cd "$CN_DIR"
                if [[ "$filename" == *"simple"* ]]; then
                    # For simplified Chinese resumes, try XeLaTeX first, fall back to pdflatex
                    xelatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                    local build_status=$?
                    if [ $build_status -ne 0 ]; then
                        echo -e "${YELLOW}XeLaTeX failed, trying pdflatex...${NC}"
                        pdflatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                        build_status=$?
                    fi
                else
                    xelatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                    local build_status=$?
                fi
                
                # Check if PDF was actually generated regardless of exit status
                if [ -f "temp/${base_name}.pdf" ]; then
                    mv "temp/${base_name}.pdf" "../$BUILD_DIR/$pdf_name"
                    if [ -f "../$BUILD_DIR/$pdf_name" ]; then
                        echo -e "${GREEN}✓ Successfully built $pdf_name${NC}"
                    else
                        echo -e "${RED}✗ Failed to move $pdf_name${NC}"
                    fi
                else
                    echo -e "${RED}✗ Failed to build $filename${NC}"
                fi
                cd ..
            fi
        done
    else
        # Check if file exists in en or cn directory
        local file_path=""
        if [ -f "$EN_DIR/$file" ]; then
            file_path="$EN_DIR/$file"
        elif [ -f "$CN_DIR/$file" ]; then
            file_path="$CN_DIR/$file"
        elif [ -f "$file" ]; then
            file_path="$file"
        else
            echo -e "${RED}Error: File $file not found in any directory${NC}"
            exit 1
        fi
        
        # Get directory and filename
        local dir=$(dirname "$file_path")
        local filename=$(basename "$file_path")
        local base_name="${filename%.tex}"
        local pdf_name="${base_name}_${DATE}.pdf"
        
        echo -e "${BLUE}Building $filename -> $pdf_name...${NC}"
        # Create build directory if it doesn't exist
        mkdir -p "$BUILD_DIR"
        mkdir -p "$dir/temp"
        
        cd "$dir"
        
        # Check if it's a Chinese resume and use appropriate compiler
        local build_success=false
        if [[ "$filename" == *"_cn"* ]]; then
            if [[ "$filename" == *"simple"* ]]; then
                # For simplified Chinese resumes, try XeLaTeX first, fall back to pdflatex
                xelatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                local build_status=$?
                if [ $build_status -ne 0 ]; then
                    echo -e "${YELLOW}XeLaTeX failed, trying pdflatex...${NC}"
                    pdflatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                    build_status=$?
                fi
            else
                xelatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
                local build_status=$?
            fi
        else
            pdflatex -output-directory="temp" -interaction=nonstopmode "$filename" > /dev/null 2>&1 || true
            local build_status=$?
        fi
        
        # Check if PDF was actually generated regardless of exit status
        if [ -f "temp/${base_name}.pdf" ]; then
            mv "temp/${base_name}.pdf" "../$BUILD_DIR/$pdf_name"
            if [ -f "../$BUILD_DIR/$pdf_name" ]; then
                build_success=true
            fi
        fi
        
        cd ..
        
        if [ "$build_success" = true ]; then
            echo -e "${GREEN}✓ Successfully built $pdf_name${NC}"
        else
            echo -e "${RED}✗ Failed to build $filename${NC}"
            exit 1
        fi
    fi
}

clean_build() {
    echo -e "${BLUE}Cleaning build artifacts...${NC}"
    rm -f "$EN_DIR"/temp/*.aux "$EN_DIR"/temp/*.log "$EN_DIR"/temp/*.out \
          "$EN_DIR"/temp/*.fdb_latexmk "$EN_DIR"/temp/*.fls "$EN_DIR"/temp/*.synctex.gz \
          "$CN_DIR"/temp/*.aux "$CN_DIR"/temp/*.log "$CN_DIR"/temp/*.out \
          "$CN_DIR"/temp/*.fdb_latexmk "$CN_DIR"/temp/*.fls "$CN_DIR"/temp/*.synctex.gz 2>/dev/null || true
    echo -e "${GREEN}✓ Build artifacts cleaned from temp directories${NC}"
}

archive_pdfs() {
    if [ ! -d "$BUILD_DIR" ] || [ -z "$(ls -A "$BUILD_DIR"/*.pdf 2>/dev/null)" ]; then
        echo -e "${RED}No PDF files found in $BUILD_DIR directory${NC}"
        exit 1
    fi
    
    local archive_path="$ARCHIVE_DIR/$DATETIME"
    mkdir -p "$archive_path"
    
    cp "$BUILD_DIR"/*.pdf "$archive_path/"
    echo -e "${GREEN}✓ PDFs archived to $archive_path${NC}"
    
    # Create a summary file
    echo "Archive created: $DATETIME" > "$archive_path/README.txt"
    echo "Git commit: $(git rev-parse HEAD 2>/dev/null || echo 'Not a git repository')" >> "$archive_path/README.txt"
    echo "Files archived:" >> "$archive_path/README.txt"
    ls -la "$archive_path"/*.pdf >> "$archive_path/README.txt"
}

list_versions() {
    echo -e "${BLUE}Available resume versions:${NC}"
    echo ""
    echo -e "${YELLOW}English Versions:${NC}"
    for tex_file in "$EN_DIR"/*.tex; do
        if [[ "$tex_file" != *"experience_pool.tex" ]]; then
            local filename=$(basename "$tex_file")
            local base_name="${filename%.tex}"
            local pdf_pattern="${base_name}_*.pdf"
            local status=""
            
            # Find the most recent PDF for this resume
            local latest_pdf=$(ls -t "$BUILD_DIR"/$pdf_pattern 2>/dev/null | head -1)
            if [ -n "$latest_pdf" ]; then
                local pdf_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$latest_pdf" 2>/dev/null || stat -c "%y" "$latest_pdf" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
                local pdf_name=$(basename "$latest_pdf")
                status="${GREEN}[Built: $pdf_date -> $pdf_name]${NC}"
            else
                status="${RED}[Not built]${NC}"
            fi
            echo -e "  $filename $status"
        fi
    done
    
    echo ""
    echo -e "${YELLOW}Chinese Versions (中文版本):${NC}"
    for tex_file in "$CN_DIR"/*.tex; do
        if [[ "$tex_file" != *"experience_pool_cn.tex" ]]; then
            local filename=$(basename "$tex_file")
            local base_name="${filename%.tex}"
            local pdf_pattern="${base_name}_*.pdf"
            local status=""
            
            # Find the most recent PDF for this resume
            local latest_pdf=$(ls -t "$BUILD_DIR"/$pdf_pattern 2>/dev/null | head -1)
            if [ -n "$latest_pdf" ]; then
                local pdf_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$latest_pdf" 2>/dev/null || stat -c "%y" "$latest_pdf" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
                local pdf_name=$(basename "$latest_pdf")
                status="${GREEN}[Built: $pdf_date -> $pdf_name]${NC}"
            else
                status="${RED}[Not built]${NC}"
            fi
            echo -e "  $filename $status"
        fi
    done
    
    if [ -d "$ARCHIVE_DIR" ] && [ "$(ls -A "$ARCHIVE_DIR" 2>/dev/null)" ]; then
        echo ""
        echo -e "${BLUE}Archived versions:${NC}"
        ls -1 "$ARCHIVE_DIR" | head -10
        local total_archives=$(ls -1 "$ARCHIVE_DIR" | wc -l)
        if [ $total_archives -gt 10 ]; then
            echo "  ... and $((total_archives - 10)) more"
        fi
    fi
}

show_diff() {
    local file1=$1
    local file2=$2
    
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        echo -e "${RED}Error: One or both files not found${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Differences between $file1 and $file2:${NC}"
    echo ""
    diff -u "$file1" "$file2" || true
}

backup_current() {
    if [ ! -d ".git" ]; then
        echo -e "${RED}Error: Not a git repository${NC}"
        exit 1
    fi
    
    git add .
    local commit_msg="Resume update: $DATETIME"
    read -p "Enter commit message (or press Enter for default): " custom_msg
    if [ ! -z "$custom_msg" ]; then
        commit_msg="$custom_msg"
    fi
    
    git commit -m "$commit_msg"
    echo -e "${GREEN}✓ Changes committed to git${NC}"
}

# Main script logic
case "$1" in
    "build")
        build_resume "$2"
        ;;
    "clean")
        clean_build
        ;;
    "archive")
        archive_pdfs
        ;;
    "list")
        list_versions
        ;;
    "diff")
        show_diff "$2" "$3"
        ;;
    "backup")
        backup_current
        ;;
    "help"|"--help"|"-h"|"")
        print_usage
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        print_usage
        exit 1
        ;;
esac
