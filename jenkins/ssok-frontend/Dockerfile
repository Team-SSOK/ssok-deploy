FROM    node:22.13.1
WORKDIR /app
COPY    package.json package-lock.json* ./
RUN     npm install --legacy-peer-deps \
        && npm install @lottiefiles/dotlottie-react --legacy-peer-deps
COPY    . .
CMD     ["npx", "expo", "start", "--port", "55026"]