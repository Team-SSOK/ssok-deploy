FROM    node:22.13.1
WORKDIR /app
COPY    package.json package-lock.json* ./
RUN     npm install
COPY    . .
CMD     ["npx", "expo", "start", "--port", "55026"]