

use Test;
BEGIN { plan tests => 1 };
use Finance::Currency::Convert::Yahoo;
ok(1); # If we made it this far, we're ok.

# $Finance::Currency::Convert::Yahoo::CHAT=1;
# print Finance::Currency::Convert::Yahoo::convert(10,'GBP','HUF');

exit;

