

for each issue exclusive-lock:

    find last IssStatus of issue no-lock no-error.

    pause 0.
    disp issue.IssueDate issStatus.ChangeDate
    when avail issStatus.

    if avail IssStatus
    then issue.IssueTime = issStatus.ChangeTime.
    else issue.IssueTime = time.
end.
