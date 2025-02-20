# Define Variables
$TOKEN = "glpat-LihCsMzgodnz3-6FU2su"
$PROJECT_ID = "67062627"
$BASE_URL = "https://gitlab.com/api/v4/projects/$PROJECT_ID"
$OUTPUT_FILE = "pipeline_output.txt"

#Fetch Project Name Dynamically
$headers = @{ "PRIVATE-TOKEN" = $TOKEN }
$projectResponse = Invoke-RestMethod -Uri $BASE_URL -Headers $headers -Method Get
$CI_PROJECT_NAME = $projectResponse.name

# Fetch pipelines
$pipelines = Invoke-RestMethod -Uri "$BASE_URL/pipelines?per_page=200" -Headers $headers -Method Get

# Prepare output
$OutputData = @()
$OutputData += "ENVIRONMENT_NAME| STATUS | TIMESTAMP  | SERVICE | DOCKER_VERSION"
$OutputData += "------------------------------------------------------------------------------------"

# Loop through each pipeline
foreach ($pipeline in $pipelines) {
    $BRANCH = $pipeline.ref
    $IID = $pipeline.iid
    $ID = $pipeline.id
    $STATUS = $pipeline.status ?? "unknown"
    $TIMESTAMP = $pipeline.created_at ?? "unknown"

    # Fetch environment details (from jobs API)
    $jobs = Invoke-RestMethod -Uri "$BASE_URL/pipelines/$ID/jobs" -Headers $headers -Method Get
    $ENVIRONMENT_NAME = if ($jobs -and $jobs[0].environment -and $jobs[0].environment.name) { $jobs[0].environment.name } else { "Unknown" }

    # Define service and Docker version
    $SERVICE = $CI_PROJECT_NAME
    $DOCKER_VERSION = "$CI_PROJECT_NAME`:$BRANCH`:$IID"

    # Append output
    $OutputData += "$ENVIRONMENT_NAME| $STATUS | $TIMESTAMP  | $SERVICE | $DOCKER_VERSION"
}

# Save output to file (overwrite existing content)
$OutputData | Set-Content -Path $OUTPUT_FILE

# Suppress console output (optional: comment out below line if you want confirmation)
Write-Host "Output saved to $OUTPUT_FILE" 
