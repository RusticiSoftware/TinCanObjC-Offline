##Creating a RSTinCanOfflineConnector

    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *lrs = [[NSMutableDictionary alloc] init];
    [lrs setValue:@"https://your.lrs" forKey:@"endpoint"];
    [lrs setValue:@"Basic mHjdyhUudhjryr7486ryHhdjsjhuuetyhgksiI*8usijdh" forKey:@"auth"];
    [lrs setValue:@"1.0.0" forKey:@"version"];
    // just add one LRS for now
    [options setValue:[NSArray arrayWithObject:lrs] forKey:@"recordStore"];
    tincan = [[RSTinCanOfflineConnector alloc]initWithOptions:options];