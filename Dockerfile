FROM node:18-bullseye

# Install Python and tooling for Slither and Solidity compiler
RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install slither-analyzer solc-select && \
    solc-select install 0.8.20 && \
    solc-select use 0.8.20

WORKDIR /workspace
COPY package*.json ./
RUN npm ci
COPY . .

CMD ["bash"]
