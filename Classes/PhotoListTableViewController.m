//
//  MyTableViewController.m
//  MyTableView
//

#import "PhotoListTableViewController.h"
#import "JSON.h"
#import "FlickrAPIKey.h"

// http://www.flickr.com/services/api/

@implementation PhotoListTableViewController

@synthesize userName;
@synthesize tagName;

- (void)loadPhotosByTag
{
    // Construct a Flickr API request.
	// Important! Enter your Flickr API key in FlickrAPIKey.h
    NSString *urlString = [NSString stringWithFormat:@"http://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=%@&user_id=%@&tags=%@&per_page=10&format=json&nojsoncallback=1", FlickrAPIKey, userName, tagName];
    NSURL *url = [NSURL URLWithString:urlString];

    // Get the contents of the URL as a string, and parse the JSON into Foundation objects.
    NSString *jsonString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *results = [jsonString JSONValue];
    
    // Now we need to dig through the resulting objects.
    // Read the documentation and make liberal use of the debugger or logs.
    NSArray *photos = [[results objectForKey:@"photos"] objectForKey:@"photo"];
    for (NSDictionary *photo in photos) {
        // Get the title for each photo
        NSString *title = [photo objectForKey:@"title"];
        [photoNames addObject:(title.length > 0 ? title : @"Untitled")];
        
        // Construct the URL for each photo.
        NSString *photoURLString = [NSString stringWithFormat:@"http://farm%@.static.flickr.com/%@/%@_%@_s.jpg", [photo objectForKey:@"farm"], [photo objectForKey:@"server"], [photo objectForKey:@"id"], [photo objectForKey:@"secret"]];
        [photoURLs addObject:[NSURL URLWithString:photoURLString]];
    }    
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        photoURLs = [[NSMutableArray alloc] init];
        photoNames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [photoURLs release];
    [photoNames release];
	[tagName release];
    
    [super dealloc];
}

- (void)viewDidLoad
{
    self.tableView.rowHeight = 95; // 75 pixel square image + 10 pixels of padding.
	self.title = @"Photos";
	[self loadPhotosByTag];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [photoNames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
 	static NSString *CellIdentifier = @"PhotoListTableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
    cell.textLabel.text = [photoNames objectAtIndex:indexPath.row];    

    NSData *imageData = [NSData dataWithContentsOfURL:[photoURLs objectAtIndex:indexPath.row]];
    cell.imageView.image = [UIImage imageWithData:imageData];
    
    return cell;
}

@end
