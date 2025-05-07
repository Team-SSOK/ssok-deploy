FROM    node:22.13.1
WORKDIR /app
COPY    package.json package-lock.json* ./
RUN     npm install \
        && npm install @lottiefiles/dotlottie-react 
COPY    . .
CMD     ["npx", "expo", "start", "--port", "55026"]