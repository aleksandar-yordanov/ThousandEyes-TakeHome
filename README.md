# Aleksandar Yordanov - ThousandEyes Take Home Project Report:

## How I Approached This Task:
First, I chose to implement this app in Swift for iOS. This is as I already had all of the tooling installed (Xcode, iOS 18.1)
and I wanted to personally refresh my Swift knowledge and demonstrate that I can adapt to new technologies quickly and easily. 

I decided to implement this with a standard Model-View-ViewModel architecture, where each component of my application adheres
to the single responsibility principle and can be tested in isolation. 

I decided to model JSON GET request data in a Site model that exactly represents the data coming from the githubusercontent site.

I then decided to create separate services for configuration and networking. 
**AppConfigService:**
    This service reads the config property list and exposes the API endpoint for other services to use.
    
**NetworkingService:**
    This service handles the networking to send GET requests and fetch from the API endpoint provided by AppConfigService.
    I only expose one method, fetchSites(), to allow other components to pull requested sites.
    This service also provides errors that are mapped to the NetworkError enum to offer errors that can be tested and traced.
    
After this I decided to implement the SiteListViewModel:
    SiteListViewModels job is to load, sort and expose site data for SiteListView and SiteRowView.
    
    It holds two arrays with site data: SiteCopy which stores data as it was received from NetworkingService and sites which stores sites
    with the ability to be sorted by the view model. This is so that when returning to a sort state of "None",
    I have a copy of the original sites to revert to.
    
    Views can call "await vm.loadSites()" and "vm.toggleSort()" to receive and sort data from the view model.
    All data that viewmodels receive is published, such that when a change occurs, views are automatically re-rendered.
    
Finally I decided to implement both SiteListView and SiteRowView:
    **SiteListView:**
        The job of this view is to order and present SiteRowViews with data provided by SiteListViewModel.
        It creates a SiteListViewModel state object to receive published data from the view model and display it in list form with SiteRowViews. 
        If data is still being pulled, I use a progress view to display a loading wheel and 
        if the is an errorMessage is not nil (published data from view model), I display an error.
        
        For sorting, the list view reads the published sort state title to display the current sorting state. If the toolbar button is pressed,
        I call "vm.toggleSort()" so that the viewmodel resorts the data and changes the published data, forcing a re-render with new data.
        
        Finally I set onTapGesture to call back to open() where the sites url is read and the app redirects to a Safari window presenting
        the requested site.

    **SiteRowView:**
        The job of this view is to represent data from the Site model. Each image URL is loaded into an SDWebImage where I use AsyncImage's
        phase matching to define how images should be rendered depending on results from SDWebImage. 
        
        I then present the the name and description as set in each Site object. 
        
After implementing every component in this app, I moved on to testing. I implemented tests for SiteModel and NetworkingService.

SiteModel tests:
    I test whether JSON data can be decoded into a Site object and whether each parameter in the Site object follows expected values.
    
NetworkingService tests:
    I use a mock URL protocol to test whether my NetworkingService performs as expected. My tests are as follows:
    1. I test a successful response with correctly formed JSON data to see whether NetworkingService provides Site objects as expected
    2. I test a failed response with the HTTP error code 500 to verify whether my networking service catches this exception and provides a requestFailed error
    3.  Finally, I test a successful response but with malformed JSON data to ensure that NetworkingService catches this and provides a decodingError

## What I am proud of:

1. My sorting implementation:
    I decided to use a case iterable enum with several states for each sorting type. This allowed me to use a computed property (next)
    to get the next case in the allCases array, wrapping around to the start when at the ending index. 
    Furthermore, this allowed me to make a make a method to mutate the state of a SortState object, 
    mutating it with the next SortState provided by the next property.
    
    This allows users to cycle through every sorting method and allows my sorting implementation to be extensible with other sorting methods.

2. My use of a mock URL protocol for testing:
    To rapidly speed up testing of my networking service, I implemented a mock URL protocol 
    (based on https://www.swiftwithvincent.com/blog/how-to-mock-any-network-call-with-urlprotocol).
    This enabled me to test the exception handling of my networking service with mock requests,
    allowing me to control returned data, status codes and more to ensure that error handling was implemented correctly.

3. My use of SDWebImage with SDWebImageSVGCoder to render SVG files for certain icons:
    One of the major issues that I faced early on, was that AsyncImage does not support SVG rendering,
    resulting in placeholder images for most of the websites listed. 
    I looked for a drop-in replacement for AsyncImage and ended up finding SDWebImage with SDWebImageSVGCoder that fit this requirement.

## What I would improve if I had more time (in order or importance):

1. I would add more tests:
    Specifically, I would introduce UI and integration tests using XCTest or the new Swift 6.0 testing framework. 
    
    I would also provide a mock URL to WebImages to observe how SDWebImage deals with malformed or invalid URLs
    and see how this would render in the final app.
    
2. I would add a refresh mechanism:
    Where, if a user drags down from the top of the app, another GET request would be sent,
    and the site view model would be updated with new sites (if applicable).

3. I would implement a cacheing mechanism:
    To handle the case where the endpoint is down, I would implement a cacheing mechanism to store sites locally. 
    I would cache associated images with kingfisher and serve these images in the case of an inaccessable endpoint.
    This would be combined with the refresh mechanism so users can refresh for new data when they can access the endpoint.
    
4. I would add in-app Safari views:
    To have a more seamless UX, I would implement redirects such that, instead of opening safari externally,
    I would have an internal safari view displaying the requested site. 
    
5. I would add localisation:
    I am personally bilingual and know many others who do not speak english. If I had more time,
    I would add localisation based on the users device language, potentially implementing Google's cloud translation API to achieve this.
    However, this may be excessive for such a small project.


