# Inception
This project aims to broaden your knowledge of system administration by using Docker.
You will virtualize several Docker images, creating them in your new personal virtual
machine.

---

## Makefile Usage

Run the following commands in the project root directory (where the Makefile is located) using your terminal:

| Command             | Description                                                                 |
|---------------------|-----------------------------------------------------------------------------|
| make create-dirs    | Creates the data/db and data/www directories.                                |
| make set-path       | Replaces `<DATA_PATH>` in docker-compose.yml with the actual data path.      |
| make reset-path     | Restores docker-compose.yml to its original state.                           |
| make build          | Builds Docker images (includes directory creation and path replacement).      |
| make create         | Only creates the containers.                                                 |
| make up             | Builds and runs the containers in the background.                            |
| make down           | Stops and removes containers and volumes (also restores the path).            |
| make clean          | Removes containers, volumes, images, and the data directory.                 |
| make re             | Runs clean and then up.                                                      |

---

## /etc/hosts Configuration

To access the service, your local machine must recognize the domain (e.g., hyeonsok.42.fr).
Add the following entry to your /etc/hosts file:

```bash
sudo vi /etc/hosts
```

Add or modify the following line:

**For local development:**
```
127.0.0.1   hyeonsok.42.fr
```

**For cloud deployment (AWS EC2, etc.):**
```
<EC2_PUBLIC_IP>   hyeonsok.42.fr
```

- Replace `<EC2_PUBLIC_IP>` with your actual EC2 instance's public IP address
- The domain (hyeonsok.42.fr) may differ depending on your docker-compose or nginx settings
- If you use multiple domains, add each one on a separate line

---
