import { Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { Request, Response } from 'express';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const ctx = context.switchToHttp();
    const request = ctx.getRequest<Request>();
    const response = ctx.getResponse<Response>();
    const { method, url, body, query, params, headers } = request;
    const userAgent = headers['user-agent'] || '';
    const ip = request.ip || request.connection.remoteAddress || '';

    const now = Date.now();
    const timestamp = new Date().toISOString();

    // Log request
    this.logger.log(
      `📨 ${method} ${url} - ${ip} - ${userAgent}`,
      JSON.stringify({
        timestamp,
        method,
        url,
        ip,
        userAgent,
        body: method !== 'GET' ? body : undefined,
        query: Object.keys(query).length ? query : undefined,
        params: Object.keys(params).length ? params : undefined,
      }),
    );

    return next.handle().pipe(
      tap({
        next: (data) => {
          const responseTime = Date.now() - now;
          const statusCode = response.statusCode;

          this.logger.log(
            `📤 ${method} ${url} - ${statusCode} - ${responseTime}ms`,
            JSON.stringify({
              timestamp: new Date().toISOString(),
              method,
              url,
              statusCode,
              responseTime,
              dataSize: JSON.stringify(data).length,
            }),
          );
        },
        error: (error) => {
          const responseTime = Date.now() - now;
          const statusCode = response.statusCode || 500;

          this.logger.error(
            `❌ ${method} ${url} - ${statusCode} - ${responseTime}ms`,
            JSON.stringify({
              timestamp: new Date().toISOString(),
              method,
              url,
              statusCode,
              responseTime,
              error: error.message,
            }),
          );
        },
      }),
    );
  }
}
