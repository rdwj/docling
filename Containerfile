FROM registry.access.redhat.com/ubi8/python-39:latest

USER 0

# Install system dependencies - replace libgl1 with appropriate UBI package
RUN dnf install -y \
    mesa-libGL \
    && dnf clean all

# Switch back to non-root user
USER 1001

# Set working directory
WORKDIR /opt/app-root/src

# Install Python dependencies
COPY --chown=1001:0 requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Pre-download the Docling model artifacts
RUN mkdir -p /opt/app-root/src/docling_models
RUN python -c "from docling.pipeline.standard_pdf_pipeline import StandardPdfPipeline; import pathlib; \
    StandardPdfPipeline.download_models_hf(pathlib.Path('/opt/app-root/src/docling_models'))"

# Set environment variables
ENV DOCLING_ARTIFACTS_PATH=/opt/app-root/src/docling_models
ENV PORT=8080

# Copy application code
COPY --chown=1001:0 app.py .

# Expose the port the app will run on
EXPOSE 8080

# Command to run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "app:app"]
