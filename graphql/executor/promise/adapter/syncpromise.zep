namespace GraphQL\Executor\Promise\Adapter;

use GraphQL\Utils\Utils;
/**
 * Class SyncPromise
 *
 * Simplistic (yet full-featured) implementation of Promises A+ spec for regular PHP `sync` mode
 * (using queue to defer promises execution)
 *
 * @package GraphQL\Executor\Promise\Adapter
 */
class SyncPromise
{
    const PENDING = "pending";
    const FULFILLED = "fulfilled";
    const REJECTED = "rejected";
    /**
     * @var \SplQueue
     */
    public static queue;
    public static function getQueue()
    {
        let self::queue =  new \SplQueue();
        return  self::queue ? self::queue : self::queue;
    }
    
    public static function runQueue() -> void
    {
        var q, task;
    
        let q =  self::queue;
        while (q && !(q->isEmpty())) {
            let task =  q->dequeue();
            {task}();
        }
    }
    
    public state = self::PENDING;
    public result;
    /**
     * Promises created in `then` method of this promise and awaiting for resolution of this promise
     * @var array
     */
    protected waiting = [];
    public function reject(reason)
    {
        if !(reason instanceof \Exception) && !(reason instanceof \Throwable) {
            throw new \Exception("SyncPromise::reject() has to be called with an instance of \\Throwable");
        }
        if self::PENDING {
            let this->state =  self::REJECTED;
            let this->result = reason;
            this->enqueueWaitingPromises();
        } elseif self::REJECTED {
            if reason !== this->result {
                throw new \Exception("Cannot change rejection reason");
            }
        } else {
            throw new \Exception("Cannot reject fulfilled promise");
        }
        return this;
    }
    
    public function resolve(value)
    {
        if self::PENDING {
            if value === this {
                throw new \Exception("Cannot resolve promise with self");
            }
            if is_object(value) && method_exists(value, "then") {
                value->then(new SyncPromiseresolveClosureOne(), new SyncPromiseresolveClosureOne());
                return this;
            }
            let this->state =  self::FULFILLED;
            let this->result = value;
            this->enqueueWaitingPromises();
        } elseif self::FULFILLED {
            if this->result !== value {
                throw new \Exception("Cannot change value of fulfilled promise");
            }
        } else {
            throw new \Exception("Cannot resolve rejected promise");
        }
        return this;
    }
    
    public function then(onFulfilled = null, onRejected = null)
    {
        var tmp;
    
        if this->state === self::REJECTED && !(onRejected) {
            return this;
        }
        if this->state === self::FULFILLED && !(onFulfilled) {
            return this;
        }
        let tmp =  new self();
        let this->waiting[] =  [tmp, onFulfilled, onRejected];
        if this->state !== self::PENDING {
            this->enqueueWaitingPromises();
        }
        return tmp;
    }
    
    protected function enqueueWaitingPromises() -> void
    {
        var descriptor, promise, onFulfilled, onRejected, tmpListPromiseOnFulfilledOnRejected, e;
    
        Utils::invariant(this->state !== self::PENDING, "Cannot enqueue derived promises when parent is still pending");
        for descriptor in this->waiting {
            let tmpListPromiseOnFulfilledOnRejected = descriptor;
            let promise = tmpListPromiseOnFulfilledOnRejected[0];
            let onFulfilled = tmpListPromiseOnFulfilledOnRejected[1];
            let onRejected = tmpListPromiseOnFulfilledOnRejected[2];
            self::getQueue()->enqueue(new SyncPromiseenqueueWaitingPromisesClosureOne(descriptor));
        }
        let this->waiting =  [];
    }

}