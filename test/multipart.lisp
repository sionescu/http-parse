(in-package :http-parse-test)

(test multipart-chunks
  "Test multipart parsing (in a complicated chunking scenario)"
  (let* ((content (file-contents (asdf:system-relative-pathname :http-parse "test/data/multipart.http")))
         (content (subseq content (+ 4 (search #(13 10 13 10) content))))
         (chunk1-sep (search (babel:string-to-octets "power") content))
         (chunk2-sep (search (babel:string-to-octets "omglol") content))
         (multipart-pieces nil)
         (parser (http-parse::make-multipart-parser
                   '(:content-type "multipart/form-data; boundary=----------------------------e74856e71fad")
                   (lambda (&rest args)
                     (push args multipart-pieces))))
         (chunk1 (subseq content 0 chunk1-sep))
         (chunk2 (subseq content chunk1-sep chunk2-sep))
         (chunk3 (subseq content chunk2-sep)))
    (funcall parser chunk1)
    (funcall parser chunk2)
    (funcall parser chunk3)
    (let ((checks (reverse multipart-pieces)))
      (is (equalp (nth 0 checks)
                  '("name" (:content-disposition "form-data; name=\"name\"") (:name "name") #(119 111 111 107 105 101) t)))
      (is (equalp (nth 1 checks)
                  '("power" (:content-disposition "form-data; name=\"power\"") (:name "power") #(103 114 111 119 108) t)))
      (is (equalp (nth 2 checks)
                  '("uploadz" (:content-disposition "form-data; name=\"uploadz\"; filename=\"test.lisp\"" :content-type "application/octet-stream") (:filename "test.lisp" :name "uploadz") #(40 102 111 114 109 97 116 32 116 32 34) nil)))
      (is (equalp (nth 3 checks)
                  '("uploadz" (:content-disposition "form-data; name=\"uploadz\"; filename=\"test.lisp\"" :content-type "application/octet-stream") (:filename "test.lisp" :name "uploadz") #(111 109 103 108 111 108 119 116 102 126 37 34 41 10) t))))))
