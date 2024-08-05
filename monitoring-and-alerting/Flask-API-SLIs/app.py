import random
import time
from time import sleep

from flask import Flask, Response, request
from prometheus_client import make_wsgi_app, Histogram, Counter
from werkzeug.middleware.dispatcher import DispatcherMiddleware


# disable default metrics
import prometheus_client
prometheus_client.REGISTRY.unregister(prometheus_client.GC_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PLATFORM_COLLECTOR)
prometheus_client.REGISTRY.unregister(prometheus_client.PROCESS_COLLECTOR)

HTTP_NUMBER_OF_REQUESTS = Counter(
    'http_number_of_requests', # This is the metric name
    'Total number of requests',
    ["method", "url", "code"],
)

HTTP_REQUEST_DURATION = Histogram(
    "http_request_duration",
    "Requests durations",
    ["method", "url", "code"],
    buckets=[0.01, 0.1, 0.5, 2, float("inf")],
)

def observe_http(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        response = func(*args, **kwargs)
        end = time.time()

        HTTP_NUMBER_OF_REQUESTS.labels(
            method=request.method,
            code=response.status_code,
            url=request.url
        ).inc()

        HTTP_REQUEST_DURATION.labels(
            method=request.method,
            code=response.status_code,
            url=request.url
        ).observe(end - start)
        return response
    return wrapper

app = Flask(__name__)
app.wsgi_app = DispatcherMiddleware(
    app.wsgi_app, {"/metrics": make_wsgi_app()}
)

@app.route("/")
@app.route("/up")
def hello():
    return "Hello world :)"

@app.route("/synthetic")
@observe_http
def synthetic():
    random_duration = random.randint(1,50) * 0.001
    sleep(random_duration)
    response_code = random.choice([200, 200, 200, 200, 400, 401, 500, 502])
    return Response(str(response_code), status=response_code)