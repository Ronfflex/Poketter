# Sample API-AUTH using Prisma

## How to Use the API

### Prerequisites

- Docker
- Bun (https://bun.sh)

### Environment Setup

Copy the `.env.example` file to create a `.env` file and adjust the variables as needed:

### API Routes Overview

The API is structured around two main routes modules: Authentication and User Management. Below is a detailed explanation of each route and its functionality:

#### Authentication Routes (`/api/auth`)

- **POST `/api/auth/register`**: Allows new users to register. Requires a username, email, and password.
- **POST `/api/auth/login`**: Allows users to login. Requires a username and password.
- **GET `/api/auth/logout`**: Logs out the user using the provided token from the Authorization header.

#### User Management Routes (`/api/user`)

- **GET `/api/user/profile`**: Retrieves the profile of the authenticated user.
- **PUT `/api/user/`**: Allows the authenticated user to update their own profile details like username, email, and password.
- **PUT `/api/user/:id`**: Admin route to update user details by user ID. Requires admin privileges.
- **DELETE `/api/user/:id`**: Admin route to delete a user by user ID. Requires admin privileges.
- **GET `/api/user/:id`**: Admin route to retrieve a user by user ID. Requires admin privileges.
- **GET `/api/user/search/:username`**: Admin route to search for a user by username. Requires admin privileges.
- **GET `/api/user/`**: Admin route to list all users. Requires admin privileges.
- **POST `/api/user/`**: Admin route to create a new user. Requires admin privileges.

Each route is equipped with appropriate middleware to handle authentication and authorization, ensuring that only authorized users can access specific functionalities.

## Run the application

### With Bun (TypeScript & JavaScript Runtime)

To run the application, you can use the following commands defined in `package.json`:

- `bun install`: Installs the dependencies.
- `bun run build`: Compiles the TypeScript files and generates Prisma client.
- `bun run start`: Runs the compiled JavaScript from the `dist` directory.
- `bun run dev`: Watches for changes in your TypeScript files and recompiles them on-the-fly.

Make sure you have all the necessary environment variables set in your `.env` file before running these commands.

### With Docker & Docker compose

To run the application using Docker, follow these steps:

1. **Set Up and Run with Docker:**

   - Ensure you have Docker installed on your machine.
   - Navigate to the root directory of the project where the `Dockerfile` is located.
   - Run the following command to build the Docker image:
     ```
     docker build -t auth-api .
     ```
     Or directly take the [image](https://hub.docker.com/r/teyik0/auth-api-sample) from the docker hub
     ```
     docker pull teyik0/auth-api-sample
     ```
   - Ensure that the Docker container for the PostgreSQL database is running. You can run a PostgreSQL container using the following command:
     ```
     docker run --name postgresdb -e POSTGRES_USER=admin -e POSTGRES_PASSWORD=adminpwd -e POSTGRES_DB=db -p 5432:5432 -d postgres
     ```
     This command will start a PostgreSQL database container named `postgresdb` with the necessary environment variables set for user, password, and database name. It will also map the port 5432 on your host to the port 5432 on the container, allowing the application to connect to it as specified in the `.env` file.
   - To run the Docker container with environment variables specified in the `.env.example`, use the following command:
     ```
     docker run -e DATABASE_URL=postgres://admin:adminpwd@postgresdb:5432/db -e PORT=3001 -e JWT_SECRET= -p 3001:3001 auth-api
     ```
     Or use the [image](https://hub.docker.com/r/teyik0/auth-api-sample) from the docker hub
     ```
     docker run -e DATABASE_URL=postgres://admin:adminpwd@postgresdb:5432/db -e PORT=3001 -e JWT_SECRET= -p 3001:3001 teyik0/auth-api-sample
     ```

2. **Set Up and Run with Docker Compose:**

   - Make sure the `.env` file is set up correctly as per the `.env.example`.
   - Use the `docker-compose.yml` file to start the services. This file defines the necessary services like the PostgreSQL database and the API itself.
   - Run the following command to start all services using Docker Compose:
     ```
     docker-compose up
     ```
   - This command will start the PostgreSQL database and the API service, ensuring that the API service waits for the database to be ready before starting.

3. **Accessing the Application:**

   - Once the services are up and running, the API will be accessible at `http://localhost:${PORT}` where `${PORT}` is the port you specified in your `.env` file (e.g., 3001).

4. **Stopping the Application:**
   - To stop and remove all running services, you can use the following command:
     ```
     docker-compose down
     ```

By following these steps, you can easily set up and run the application in a Dockerized environment, ensuring consistency across different development and production setups.
