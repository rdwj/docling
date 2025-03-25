import os
import json
import tempfile
from flask import Flask, request, jsonify
from werkzeug.utils import secure_filename
from docling.document_converter import DocumentConverter
from docling.datamodel.document import ConversionResult
from docling.datamodel.base_models import InputFormat
from docling.document_converter import PdfFormatOption
from docling.datamodel.pipeline_options import PdfPipelineOptions

app = Flask(__name__)

# Configure maximum file size to 16MB
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024

@app.route('/', methods=['GET'])
def index():
    return jsonify({
        "status": "ok",
        "service": "docling-service",
        "message": "Service is running. Send a POST request to /process with a PDF file to process it."
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"})

@app.route('/process', methods=['POST'])
def process_pdf():
    if 'file' not in request.files:
        return jsonify({"error": "No file part in the request"}), 400
    
    file = request.files['file']
    
    if file.filename == '':
        return jsonify({"error": "No file selected"}), 400
    
    if not file.filename.lower().endswith('.pdf'):
        return jsonify({"error": "Only PDF files are supported"}), 400

    # Save the uploaded file to a temporary location
    with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as temp_file:
        file.save(temp_file.name)
        local_path_in = temp_file.name

    try:
        # Set up docling with pipeline options
        pipeline_opts = PdfPipelineOptions(
            do_ocr=request.form.get('do_ocr', 'false').lower() == 'true',
            do_table_structure=request.form.get('do_table_structure', 'true').lower() == 'true'
        )
        pdf_opts = PdfFormatOption(pipeline_options=pipeline_opts)

        doc_converter = DocumentConverter(
            format_options={InputFormat.PDF: pdf_opts}
        )

        # Convert the PDF
        conversion_result: ConversionResult = doc_converter.convert(local_path_in)

        # Export as JSON
        docling_result = conversion_result.document.export_to_dict()

        # Delete the temporary file
        os.unlink(local_path_in)

        return jsonify(docling_result)
    
    except Exception as e:
        # Clean up the temporary file in case of error
        if os.path.exists(local_path_in):
            os.unlink(local_path_in)
        
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
