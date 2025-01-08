# Running the Flutter Linux App via Docker

This guide will walk you through setting up and running the Flutter Linux app using Docker. Follow these steps carefully to ensure everything works correctly.

---

## **Prerequisites**
1. A Linux-based operating system (Ubuntu).
2. Administrative privileges to install software.
3. Internet access to download dependencies.

---

## **Step 1: Install Docker**

### **Ubuntu**
1. Update the package database:
   ```bash
   sudo apt update
   ```
2. Install required dependencies:
   ```bash
   sudo apt install -y ca-certificates curl gnupg lsb-release
   ```
3. Add Docker's official GPG key:
   ```bash
   sudo mkdir -p /etc/apt/keyrings
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
   ```
4. Set up the repository:
   ```bash
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
   ```
5. Install Docker Engine:
   ```bash
   sudo apt update
   sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin
   ```
6. Verify Docker installation:
   ```bash
   docker --version
   ```

---

## **Step 2: Clone the Project**
1. Clone the project repository:
   ```bash
   git clone <project-repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd <project-directory>
   ```

---

## **Step 3: Build the Docker Image**
1. Build the Docker image using the provided `Dockerfile`:
   ```bash
   sudo docker build -t flutter_app .
   ```

---

## **Step 4: Enable GUI Support for Linux Desktop 
1. Allow access to your X server:
   ```bash
   xhost +local:
   ```
2. Run the container with GUI support:
   ```bash
   docker run --rm -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix flutter-linux-app
   ```
---


## **Step 5: Run the Docker Container****


1. Run the container:
   ```bash
   docker run -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network=host flutter_app:latest ./build/linux/x64/release/bundle/example
   ```



---
## **To run the code on different locations outside the container 
## Steps to Copy the Build App to Documents
Run the Docker Container and Build the App
Use the following command to generate the release bundle and mount it to your host machine:

``` bash
docker run -v ~/Documents:/output -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --network=host flutter_app:latest flutter build linux --release
```
Replace ~/Documents with the desired target directory path on your host machine.
## **Troubleshooting**
1. **Docker Permission Denied**:
   - Add your user to the Docker group:
     ```bash
     sudo usermod -aG docker $USER
     ```
   - Log out and log back in for changes to take effect.

2. **Missing Dependencies**:
   - Ensure all required tools are installed in the Docker image as part of the `Dockerfile`.

3. **Cannot Connect to Display**:
   - Ensure your X server is running.
   - Allow Docker containers to access your display by running `xhost +local:`.

---



By following these steps, you should be able to successfully run the Flutter Linux app on your client’s device using Docker.

