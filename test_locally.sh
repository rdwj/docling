#!/bin/bash

# Check if a PDF file was provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <path-to-pdf-file>"
    exit 1
fi

PDF_PATH=$1
OUTPUT_DIR="../testing/output"

# Ensure the output directory exists
mkdir -p $OUTPUT_DIR

# Copy the PDF to the input directory that's mounted to the pdf-processor container
echo "Copying PDF to input directory..."
cp "$PDF_PATH" "../testing/pdf/"

# Wait for the PDF to be processed
echo "Waiting for PDF processing..."
echo "You can check the pdf-processor logs with: podman logs graph-service-pdf-processor-1"
echo "Or monitor the output directory for JSON files."

# Check if the visualization service is accessible
echo "Verifying visualization service is running..."
curl -s http://localhost:8050 > /dev/null
if [ $? -eq 0 ]; then
    echo "Visualization service is accessible at http://localhost:8050"
else
    echo "Warning: Visualization service is not responding."
fi

# Check if the GraphRAG service is accessible
echo "Verifying GraphRAG service is running..."
curl -s http://localhost:5050 > /dev/null
if [ $? -eq 0 ]; then
    echo "GraphRAG service is accessible at http://localhost:5050"
else
    echo "Warning: GraphRAG service is not responding."
fi

echo "Test complete! Open http://localhost:8050 to view the visualization."
echo "Use http://localhost:5050 to query the document using GraphRAG."
