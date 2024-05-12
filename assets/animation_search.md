## Transition - From Map to Text Search
#### Problem: UI animation is abrupt and user waits on animation to complete
#### Goal: Change app context from pan and zoom to text input search with minimal delay

### Discussion
***Solution***

Implement `MaterialApp`'s onGenerateRoute callback to apply a `FadeTransition` instead of a platform default with a custom transition 50ms for navigation to the search page and 0ms navigation away from the search page.

***Terminology***

- Widget: a Flutter UI element
- Search field: the text field
- Search widget: the UI element that contains a search field and displays search results

***Challenges***
- Application architecture / view structure
- Synchronizing widget state
- Animation in decoupled relationship

***Implementation***

This example uses the MaterialApp's navigator widget to push a new page onto the navigation stack. The push operation uses a custom transition which animates only the page's opacity (not the position of UI elements) instead of the default Material Page Route. Along with the static elements and animation curves applied, the animation happens subtly. Most importantly the user is able to start searching almost instantly, as the text field has the auto-focus flag enabled.

The Navigator approach presents several unique challenges outlined above. The navigator provides a means to decouple the search page from the map page, instead of coupling the widgets by placing them in a shared parent widget. Placing them in a shared parent widget, allows the parent to easily toggle the visibility of the search page and pass any state between the map and search widgets. The parent widget can simply create a listenable property and pass that property by reference to both the map and search widgets, since it's responsible for creating both of those widgets. Then the search widget can update the shared state and the changes will be reflected on the map widget.

On the other hand, the navigator approach requires a bit of engineering to achieve the same behavior. Since the map widget's parent can no longer directly pass the required state to the search widget, it must do so by passing values via the navigator. Applications generally contain a Navigator object near the top of the widget tree which is then passed down the tree as widgets are added. The application registers pages or callbacks with the navigator to handle setup of new widgets. The navigator has several asynchronous "push" functions which accept any type of object to be passed from the caller to the target widget. While the dynamic typing provides great flexibility, it also puts onus on the developer to ensure the correct type has been passed to the target widget. 

In example app, the map page calls the navigator's pushNamed() method, passing in the page name and any text displayed in the search field, which is used to populate the search page's text field. When the user finishes the search, it's reasonable that the map page's search field updates as well. In the navigator, push is paired with pop, which dismisses pages. Upon search completion, pop is called with the updated search text. If the push has been awaited, it will then complete the async push operation and return the value that was passed into the pop function. The example app uses the returned value to update the map's search field, in turn synchronizing the data.

With the navigator approach, customizing animations is also less straight-forward. Since the views are decoupled, the map's parent widget must rely on the navigator to control the animation. Navigator provides a couple entry points to explicitly animate our widgets. The entry point depends on how dynamic the navigation should be. For more declarative routing, we can pass in a list of pages that our application can display. The list of pages inherit from the `Page` class, so we can override the implementation to customize its animation there. Or, for more imperative routing, we can supply implementations for callback functions like navigator's onGenerateRoute parameter where we control the animation.

In our example app, the simpler imperative style of routing has been implemented in a separate class. The class defines a function that contains the page presentation logic. The function list of all the routes that our app might load and defines how they should be presented when navigating to them. In this logic, we swap the MaterialPageRoute for a custom page route that applies a fade transition and changes the transition's default duration from 300ms to 50ms and 0ms for the push and pop animations.

