import { ConfigService } from '@nestjs/config';
import * as winston from 'winston';

export const createWinstonLogger = (configService: ConfigService) => {
  const logLevel = configService.get<string>('logging.level') || 'info';
  const logFormat = configService.get<string>('logging.format') || 'json';
  const isProduction = configService.get<string>('NODE_ENV') === 'production';

  const formats = [
    winston.format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss',
    }),
    winston.format.errors({ stack: true }),
    winston.format.metadata({ fillExcept: ['message', 'level', 'timestamp'] }),
  ];

  if (logFormat === 'json') {
    formats.push(winston.format.json());
  } else {
    formats.push(
      winston.format.colorize({ all: !isProduction }),
      winston.format.printf(({ timestamp, level, message, metadata, stack }) => {
        let log = `${timestamp} [${level}] ${message}`;

        if (metadata && typeof metadata === 'object' && Object.keys(metadata).length > 0) {
          log += ` ${JSON.stringify(metadata)}`;
        }

        if (stack) {
          log += `\n${stack}`;
        }

        return log;
      }),
    );
  }

  const transports: winston.transport[] = [
    new winston.transports.Console({
      level: logLevel,
      handleExceptions: true,
      handleRejections: true,
    }),
  ];

  // Add file transports in production
  if (isProduction) {
    transports.push(
      new winston.transports.File({
        filename: 'logs/error.log',
        level: 'error',
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
      new winston.transports.File({
        filename: 'logs/combined.log',
        maxsize: 5242880, // 5MB
        maxFiles: 5,
      }),
    );
  }

  return {
    level: logLevel,
    format: winston.format.combine(...formats),
    transports,
    exitOnError: false,
  };
};
