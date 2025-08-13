import { Injectable, ExecutionContext, HttpException, HttpStatus } from '@nestjs/common';
import { ThrottlerGuard as NestThrottlerGuard } from '@nestjs/throttler';
import { Request } from 'express';

@Injectable()
export class ThrottlerGuard extends NestThrottlerGuard {
  protected override async getTracker(request: Request): Promise<string> {
    // Use a combination of IP and user ID (if authenticated) for tracking
    const ip = request.ip || request.connection.remoteAddress || 'unknown';

    // If you have authentication, you can add user ID here
    // const userId = request.user?.id;
    // return userId ? `${userId}:${ip}` : ip;

    return ip;
  }

  protected override generateKey(context: ExecutionContext, tracker: string, name: string): string {
    const request = context.switchToHttp().getRequest<Request>();
    const route = request.route?.path || request.url;

    // Create a more specific key that includes the route
    return `${name}:${tracker}:${route}`;
  }

  protected override async throwThrottlingException(context: ExecutionContext): Promise<void> {
    const request = context.switchToHttp().getRequest<Request>();

    throw new HttpException(
      {
        statusCode: HttpStatus.TOO_MANY_REQUESTS,
        message: 'Too Many Requests',
        error: 'ThrottlerException',
        timestamp: new Date().toISOString(),
        path: request.url,
        method: request.method,
        details: 'Rate limit exceeded. Please try again later.',
      },
      HttpStatus.TOO_MANY_REQUESTS,
    );
  }
}
