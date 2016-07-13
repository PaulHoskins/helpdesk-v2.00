eval {
        (new Mail::Sender)
        ->MailMsg({smtp => 'mail.btopenworld.com',
                from => 'pa_hoskins@btopenworld.com',
                to =>'pa_hoskins@btopenworld.com',
                subject => 'this is a test',
                msg => "Send simple?"})
 }
 or die "$Mail::Sender::Error\n";