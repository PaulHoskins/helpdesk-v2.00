use Mail::Sender;
$sender = new Mail::Sender {smtp => 'mail.btopenworld.com', from => 'pa_hoskins@btopenworld.com'};
$sender->MailMsg({to => 'pa_hoskins@hotmail.com', subject => 'Here is the file', msg => "I'm sending you the list you wanted."});
