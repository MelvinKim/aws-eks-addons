# Set base image
FROM python:alpine

# set working directory
WORKDIR /app

# Copy code
COPY . .

# install requirements
RUN pip install -r requirements.txt

# expose port
EXPOSE 5000

# start application
ENTRYPOINT [ "flask", "run", "-h", "0.0.0.0", "-p", "5000" ]