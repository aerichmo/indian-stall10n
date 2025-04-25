# infra/services.tf
# Enable every Google Cloud API the pipeline relies on.
# Terraform will enable any missing service and keep state
# so future runs stay green.

locals {
  apis = [
    # Core build + deploy
    "cloudbuild.googleapis.com",
    "cloudfunctions.googleapis.com",
    "eventarc.googleapis.com",        # Pub/Sub triggers for CFv2
    "cloudscheduler.googleapis.com",

    # Streaming + prediction pipeline (future-proof)
    "pubsub.googleapis.com",
    "dataflow.googleapis.com",
    "run.googleapis.com",
    "aiplatform.googleapis.com"
  ]
}

resource "google_project_service" "required" {
  for_each                   = toset(local.apis)
  service                    = each.value
  disable_dependent_services = false
}
