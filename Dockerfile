# Используем официальный образ Node.js в качестве базового
FROM node:18-alpine

# Устанавливаем pnpm, если он не включен в образ
RUN npm install -g pnpm

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем файл package.json и pnpm-lock.yaml для установки зависимостей
COPY package.json pnpm-lock.yaml ./

# Устанавливаем зависимости с помощью pnpm
RUN pnpm install --frozen-lockfile

# Копируем все остальные файлы приложения в контейнер
COPY . .

# Собираем приложение, если требуется сборка (можно использовать pnpm build или другой скрипт)
# RUN pnpm run build

# Указываем команду для запуска приложения
CMD ["pnpm", "run", "deploy"]

# Указываем порт, если приложение слушает конкретный порт
# EXPOSE 3000
