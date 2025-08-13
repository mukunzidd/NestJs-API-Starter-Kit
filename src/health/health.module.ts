import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health.controller';
import { AppLifecycleService } from '../common/lifecycle/app-lifecycle.service';

@Module({
  imports: [TerminusModule],
  controllers: [HealthController],
  providers: [AppLifecycleService],
  exports: [AppLifecycleService],
})
export class HealthModule {}
