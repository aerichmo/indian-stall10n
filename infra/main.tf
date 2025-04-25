terraform {
  backend "gcs" {
    bucket = "indianstall10n-terraform-state"  # <<< exact bucket name
    prefix = "infra"
  }

  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "indianstall10n"
  region  = var.region
}

# ──────────────────────────────────────────────────────────────
#  Bucket to store Cloud Function source code (ingest.zip)
# ──────────────────────────────────────────────────────────────
resource "google_storage_bucket" "source" {
  name          = "indianstall10n-cf-source"   # must be globally unique
  location      = var.region
  force_destroy = true
}

locals {
  tracks      = ["oaklawn", "remington", "fairmeadows"]
  code_bucket = google_storage_bucket.source.name
}

# ──────────────────────────────────────────────────────────────
#  Pub/Sub topics
# ──────────────────────────────────────────────────────────────
resource "google_pubsub_topic" "race_raw"     { name = "race_raw" }
resource "google_pubsub_topic" "results_raw"  { name = "results_raw" }
resource "google_pubsub_topic" "start_ingest" { name = "start_ingest" }

# ──────────────────────────────────────────────────────────────
#  Ingest Cloud Functions (one per track)
# ──────────────────────────────────────────────────────────────
resource "google_cloudfunctions2_function" "ingest" {
  for_each = toset(local.tracks)

  name     = "ingest-${each.key}"
  location = var.region

  build_config {
    runtime     = "python311"
    entry_point = "main"
    source {
      storage_source {
        bucket = local.code_bucket        # ← fixed bucket reference
        object = "ingest.zip"             # upload later
      }
    }
  }

  service_config {
    min_instance_count = 0
    max_instance_count = 1
    environment_variables = {
      TRACK     = each.key
      API_USER  = var.api_user
      API_PASS  = var.api_pass
      RAW_TOPIC = google_pubsub_topic.race_raw.name
    }
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.start_ingest.id
  }
}

# ──────────────────────────────────────────────────────────────
#  Cloud Scheduler job to start ingest each morning (10 a.m. CT)
# ──────────────────────────────────────────────────────────────
resource "google_cloud_scheduler_job" "ignite" {
  name      = "start-ingest"
  schedule  = var.cron
  time_zone = "America/Chicago"

  pubsub_target {
    topic_name = google_pubsub_topic.start_ingest.id
    data       = base64encode("{}")
  }
}
