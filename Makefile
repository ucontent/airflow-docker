#
PREFIX  :=  "/app/airflow"
BASE    :=  "dellelce/py-base"
TARGET  :=  "dellelce/airflow"

#default target

help:
	@no help available

build:
	@docker build -t $(TARGET) .

# check version of python in base image
pyvers: 
	@docker run -it --rm $(BASE) python3 -V
