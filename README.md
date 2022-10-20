```mermaid
graph TD
    U[\UpstreamMessages/] --> MessageIteratorNext
    MessageIteratorNext --> Dispatcher
    Dispatcher --> Callbacks
    Callbacks --Push Messages--> MessageIteratorNext
    MessageIteratorNext --Pop Messages----> D[/DownStreamMessages\]
```
