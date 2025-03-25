# Docling Service for OpenShift

This is a containerized version of the Docling PDF processing service, designed to run on OpenShift. It provides a REST API for processing PDF documents using the Docling library.

## Features

- REST API for PDF document processing
- Can be deployed to OpenShift or run locally in Podman
- Health check endpoint for container orchestration
- Configurable options for OCR and table structure extraction

## Local Development and Testing

### Building the Podman Image

```bash
# Navigate to the openshift directory
cd /path/to/docling_service/versions/openshift

# Build the Podman image
podman build -t docling-service:latest .
```

### Running the Container Locally

```bash
# Run the container, mapping port 8080 to local port 8080
podman run -p 8080:8080 --name docling-service docling-service:latest
```

### Testing with a PDF Document

You can use curl to test the service with a PDF file:

```bash
curl -X POST -F "file=@/path/to/your/document.pdf" -F "do_ocr=false" -F "do_table_structure=true" http://localhost:8080/process -o output.json
```

Or use a tool like Postman to send a POST request to http://localhost:8080/process with a form-data body containing:
- file: [your PDF file]
- do_ocr: true/false (optional, default is false)
- do_table_structure: true/false (optional, default is true)

## Deploying to OpenShift

### Prerequisites

- OpenShift CLI (`oc`) installed and configured
- Access to an OpenShift cluster
- Podman image pushed to a registry accessible by OpenShift

### Pushing the Podman Image to a Registry

```bash
# Tag the image for your registry
podman tag docling-service:latest <your-registry>/docling-service:latest

# Push the image
podman push <your-registry>/docling-service:latest
```

### Deploying with the Provided YAML

1. Update the image reference in `openshift-deployment.yaml` to point to your registry.
2. Apply the YAML to your OpenShift cluster:

```bash
oc apply -f openshift-deployment.yaml
```

### Serverless Deployment (Optional)

For a serverless deployment using OpenShift Serverless (Knative), you can use the following YAML:

```bash
oc apply -f openshift-serverless.yaml
```

### Accessing the Service

Once deployed, the service can be accessed via the OpenShift Route that was created:

```bash
# Get the route URL
oc get route docling-service
```

## API Endpoints

- `GET /`: Service information
- `GET /health`: Health check endpoint
- `POST /process`: Process a PDF document
  - Form parameters:
    - `file`: The PDF file to process (required)
    - `do_ocr`: Whether to perform OCR (optional, default is false)
    - `do_table_structure`: Whether to extract table structure (optional, default is true)

## Resource Requirements

The service requires approximately:
- 1-2 GB of memory (depending on PDF complexity)
- 0.5-1 CPU core
- ~500 MB of disk space for the container image and model artifacts
