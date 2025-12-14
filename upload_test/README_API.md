# Edge Impulse API Test Documentation

## APIs Tested

### 1. Training API
- Method: POST
- Endpoint: /v1/api/{projectId}/jobs/train
- Header:
  - x-api-key
- Success Response:
```json
{
  "success": true,
  "jobId": 12345
}
