export function formatTimestamp(timestamp: Date | string | number): string {
    const date = new Date(timestamp);
  
    if (isNaN(date.getTime())) {
      return "Invalid Date";
    }
  
    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      timeZoneName: 'short',
    };
  
    return date.toLocaleString('en-US', options);
  }