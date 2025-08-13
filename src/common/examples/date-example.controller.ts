import { Controller, Get, Query } from '@nestjs/common';
import { ParseDatePipe, ParseOptionalDatePipe } from '../pipes/parse-date.pipe';
import { ThrottleEndpoint } from '../decorators/throttle.decorator';

/**
 * Example controller demonstrating NestJS 11 ParseDatePipe usage
 * This controller is for demonstration purposes and can be removed in production
 */
@Controller('examples/dates')
export class DateExampleController {
  @Get('range')
  @ThrottleEndpoint.Moderate()
  getDateRange(
    @Query('startDate', ParseDatePipe) startDate: Date,
    @Query('endDate', ParseOptionalDatePipe) endDate?: Date,
  ) {
    const result = {
      startDate: startDate.toISOString(),
      endDate: endDate?.toISOString() || null,
      daysBetween: endDate
        ? Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24))
        : null,
      timestamp: new Date().toISOString(),
    };

    return {
      message: 'Date range processed successfully',
      data: result,
    };
  }

  @Get('validate')
  @ThrottleEndpoint.Lenient()
  validateDate(@Query('date', ParseDatePipe) date: Date) {
    const now = new Date();
    const isInFuture = date > now;
    const isInPast = date < now;

    return {
      message: 'Date validation completed',
      data: {
        inputDate: date.toISOString(),
        currentDate: now.toISOString(),
        isInFuture,
        isInPast,
        daysDifference: Math.ceil((date.getTime() - now.getTime()) / (1000 * 60 * 60 * 24)),
        formattedDate: {
          iso: date.toISOString(),
          local: date.toLocaleString(),
          utc: date.toUTCString(),
        },
      },
    };
  }
}
