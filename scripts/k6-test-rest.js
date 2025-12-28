import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

const errorRate = new Rate('errors');

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 100 },
    { duration: '30s', target: 500 },
    { duration: '1m', target: 1000 },
    { duration: '30s', target: 0 },
  ],
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'],
    errors: ['rate<0.01'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

export default function () {
  // Test GET (Consulter)
  const getRes = http.get(`${BASE_URL}/api/rest/reservations/1`);
  const getSuccess = check(getRes, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
  
  errorRate.add(!getSuccess);
  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/rest-throughput.json': JSON.stringify(data, null, 2),
  };
}

