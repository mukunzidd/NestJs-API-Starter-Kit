import { Controller, Get } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  HealthCheck,
  HealthCheckService,
  TypeOrmHealthIndicator,
  MemoryHealthIndicator,
  DiskHealthIndicator,
} from '@nestjs/terminus';

import { ThrottleEndpoint } from '../common/decorators/throttle.decorator';

@Controller('health')
export class HealthController {
  constructor(
    private health: HealthCheckService,
    private db: TypeOrmHealthIndicator,
    private memory: MemoryHealthIndicator,
    private disk: DiskHealthIndicator,
    private configService: ConfigService,
  ) {}

  @Get()
  @HealthCheck()
  @ThrottleEndpoint.Lenient()
  check() {
    return this.health.check([
      // Database connectivity
      () => this.db.pingCheck('database'),

      // Memory usage (heap should not use more than 150MB)
      () => this.memory.checkHeap('memory_heap', 150 * 1024 * 1024),

      // Memory usage (RSS should not use more than 150MB)
      () => this.memory.checkRSS('memory_rss', 150 * 1024 * 1024),

      // Disk storage should have at least 250MB free
      () =>
        this.disk.checkStorage('storage', {
          path: '/',
          thresholdPercent: 0.9,
        }),
    ]);
  }

  @Get('info')
  @ThrottleEndpoint.Moderate()
  getInfo() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: this.configService.get<string>('NODE_ENV'),
      version: this.configService.get<string>('app.version'),
      name: this.configService.get<string>('app.name'),
      description: this.configService.get<string>('app.description'),
      node_version: process.version,
      memory_usage: process.memoryUsage(),
      platform: process.platform,
      arch: process.arch,
    };
  }

  @Get('ready')
  @ThrottleEndpoint.Lenient()
  ready() {
    return {
      status: 'ready',
      timestamp: new Date().toISOString(),
    };
  }

  @Get('live')
  @ThrottleEndpoint.Lenient()
  live() {
    return {
      status: 'live',
      timestamp: new Date().toISOString(),
    };
  }
}
