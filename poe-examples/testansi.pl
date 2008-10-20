    use Term::ANSIColor;
    print color 'bold blue';
    print "This text is bold blue.\n";
    print color 'reset';
    print "This text is normal.\n";
    print colored ("Yellow on magenta.\n", 'yellow on_magenta');
    print "This text is normal.\n";
    print colored ['yellow on_magenta'], "Yellow on magenta.\n";

 
