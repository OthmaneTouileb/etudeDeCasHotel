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

const query = `
  query {
    reservations {
      id
      dateDebut
      dateFin
    }
  }
`;

export default function () {
  const payload = JSON.stringify({ query });
  const params = {
    headers: { 'Content-Type': 'application/json' },
  };
  
  const res = http.post(`${BASE_URL}/graphql`, payload, params);
  const success = check(res, {
    'status is 200': (r) => r.status === 200,
  });
  
  errorRate.add(!success);
  sleep(1);
}

export function handleSummary(data) {
  return {
    'results/graphql-throughput.json': JSON.stringify(data, null, 2),
  };
}

