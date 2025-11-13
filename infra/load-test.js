import http from 'k6/http';

export default function () {
  http.get('https://mwcorp01-dev-webapi.azurewebsites.net');
}
