FROM python:3.10-alpine3.18

COPY ../requirements.txt .

RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000

ENV PYTHONNUNBUFFERED=1

CMD ["python", "app.py"]
