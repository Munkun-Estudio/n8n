FROM node:22.16.0-slim

# Puppeteer & system dependencies
RUN apk add --no-cache \
  chromium \
  nss \
  freetype \
  harfbuzz \
  ca-certificates \
  ttf-freefont \
  udev \
  ttf-liberation \
  font-noto-emoji \
  python3 \
  build-base

# Set working directory inside the container
WORKDIR /usr/src/app

# Copy your forked n8n repo (with cheerio already added)
COPY . .

# Install pnpm and project dependencies
RUN npm install -g pnpm
RUN pnpm install
RUN pnpm build

# Install custom nodes you previously used
RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm install \
      n8n-nodes-document-generator \
      n8n-nodes-run-node-with-credentials-x \
      @itustudentcouncil/n8n-nodes-basecamp \
      n8n-nodes-puppeteer \
      puppeteer-core \
      n8n-nodes-browserless

# Let n8n resolve the extra packages
ENV NODE_PATH=/home/node/.n8n/nodes/node_modules

# Set Puppeteer Chromium path
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

EXPOSE 5678

# Start n8n using your fork
CMD ["pnpm", "exec", "n8n"]