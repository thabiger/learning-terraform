variable "name" {
    description = "A name for the bucket"
    type        = string
}

variable "tags" {
    description = "Tags for the bucket"
    type        = map
    default     = {}
}