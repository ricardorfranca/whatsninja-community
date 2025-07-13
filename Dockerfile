# Estágio 1: Build do Frontend
# Usamos uma imagem Node.js para criar o ambiente de build
FROM node:18-slim as frontend-builder

# Define o diretório de trabalho dentro do contêiner
WORKDIR /app/frontend

# Copia os arquivos de configuração de dependências primeiro para aproveitar o cache do Docker
COPY frontend/package*.json ./

# Instala as dependências do frontend
RUN npm install

# Copia todo o código do frontend
COPY frontend/ ./

# Executa o comando de build para gerar os arquivos estáticos
RUN npm run build


# Estágio 2: Preparação do Backend (a imagem final)
# Começamos com uma nova imagem Node.js limpa
FROM node:18-slim as backend-production

# Define o diretório de trabalho
WORKDIR /app/backend

# Copia os arquivos de configuração de dependências do backend
COPY backend/package*.json ./

# Instala apenas as dependências de produção
RUN npm install --omit=dev

# Copia todo o código do backend
COPY backend/ ./

# --- A MÁGICA ACONTECE AQUI ---
# Copia os arquivos "buildados" do estágio 'frontend-builder' para a pasta public do backend
COPY --from=frontend-builder /app/frontend/build ./public

# Expõe a porta que a aplicação vai usar dentro do contêiner
EXPOSE 3030

# Comando padrão para iniciar a aplicação
CMD ["npm", "start"]
