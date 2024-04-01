# AWS create DB

Scripts and template to create a private AWS RDS instance hosting a PostgreSQL database.

A public EC2 instance is also created to allow access to the database.

See also:
- [github.com/e-mit/aws-ec2-grafana](https://github.com/e-mit/aws-ec2-grafana) to configure and deploy Grafana on the EC2 to display a public dashboard with PostgreSQL data
- [github.com/e-mit/aws-lambda-get](https://github.com/e-mit/aws-lambda-get) and [github.com/e-mit/aws-lambda-db](https://github.com/e-mit/aws-lambda-db) for gathering data into the RDS using Lambda functions
