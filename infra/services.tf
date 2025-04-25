# infra/services.tf
# Enable all GCP APIs the pipeline needs

locals {
  apis = [
    "cloudbuild.googleapis.com",      # builds Cloud Functions containers
    "cloudscheduler.googleapis.com",  # daily start‐ingest job
    "eventarc.googleapis.com",
    "run.googleapis.com",             # Cloud Run (future)
    "dataflow.googleapis.com",        # streaming ETL (future)
    "aiplatform.googleapis.com",      # Vertex AI (future)
    "pubsub.googleapis.com",          # already implicitly on, but safe
    "cloudfunctions.googleapis.com"   # CFv2 itself
  ]
}

resource "google_project_service" "required" {
  for_each                   = toset(local.apis)
  service                    = each.key
  disable_dependent_services = false
}
