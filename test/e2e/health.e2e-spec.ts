import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { AppModule } from '../../src/app.module';
import { createTestApp, closeTestApp } from '../setup-e2e';

describe('Health (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createTestApp(AppModule);
  });

  afterAll(async () => {
    await closeTestApp();
  });

  describe('/health (GET)', () => {
    it('should return health status', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.body).toHaveProperty('status');
          expect(res.body).toHaveProperty('info');
          expect(res.body).toHaveProperty('details');
        });
    });

    it('should check database connectivity', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.body.details).toHaveProperty('database');
        });
    });

    it('should check memory usage', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.body.details).toHaveProperty('memory_heap');
          expect(res.body.details).toHaveProperty('memory_rss');
        });
    });

    it('should check disk storage', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.body.details).toHaveProperty('storage');
        });
    });
  });

  describe('/health/info (GET)', () => {
    it('should return application info', () => {
      return request(app.getHttpServer())
        .get('/health/info')
        .expect(200)
        .expect((res) => {
          expect(res.body).toEqual({
            status: 'ok',
            timestamp: expect.any(String),
            uptime: expect.any(Number),
            environment: 'test',
            version: '1.0.0-test',
            name: 'Test App',
            description: 'Test Application',
            node_version: process.version,
            memory_usage: expect.any(Object),
            platform: process.platform,
            arch: process.arch,
          });
        });
    });

    it('should have valid timestamp', () => {
      return request(app.getHttpServer())
        .get('/health/info')
        .expect(200)
        .expect((res) => {
          const timestamp = new Date(res.body.timestamp);
          expect(timestamp).toBeInstanceOf(Date);
          expect(timestamp.getTime()).not.toBeNaN();
        });
    });
  });

  describe('/health/ready (GET)', () => {
    it('should return ready status', () => {
      return request(app.getHttpServer())
        .get('/health/ready')
        .expect(200)
        .expect((res) => {
          expect(res.body).toEqual({
            status: 'ready',
            timestamp: expect.any(String),
          });
        });
    });
  });

  describe('/health/live (GET)', () => {
    it('should return live status', () => {
      return request(app.getHttpServer())
        .get('/health/live')
        .expect(200)
        .expect((res) => {
          expect(res.body).toEqual({
            status: 'live',
            timestamp: expect.any(String),
          });
        });
    });
  });

  describe('Error handling', () => {
    it('should return 404 for non-existent endpoints', () => {
      return request(app.getHttpServer()).get('/health/nonexistent').expect(404);
    });
  });
});
