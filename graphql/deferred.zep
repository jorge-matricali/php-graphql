namespace GraphQL;

use GraphQL\Executor\Promise\Adapter\SyncPromise;
class Deferred
{
    /**
     * @var \SplQueue
     */
    protected static queue;
    /**
     * @var callable
     */
    protected callback;
    /**
     * @var SyncPromise
     */
    public promise;
    public static function getQueue()
    {
        let self::queue =  new \SplQueue();
        return  self::queue ? self::queue : self::queue;
    }
    
    public static function runQueue() -> void
    {
        var q, dfd;
    
        let q =  self::queue;
        while (q && !(q->isEmpty())) {
            /** @var self $dfd */
            let dfd =  q->dequeue();
            dfd->run();
        }
    }
    
    public function __construct(callback) -> void
    {
        let this->callback = callback;
        let this->promise =  new SyncPromise();
        self::getQueue()->enqueue(this);
    }
    
    public function then(onFulfilled = null, onRejected = null)
    {
        return this->promise->then(onFulfilled, onRejected);
    }
    
    protected function run() -> void
    {
        var cb, e;
    
        try {
            let cb =  this->callback;
            this->promise->resolve({cb}());
        } catch \Exception, e {
            this->promise->reject(e);
        } catch \Throwable, e {
            this->promise->reject(e);
        }
    }

}